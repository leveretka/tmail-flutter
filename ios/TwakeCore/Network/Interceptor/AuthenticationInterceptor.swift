import Alamofire
import Foundation

class AuthenticationInterceptor: RequestInterceptor {
    var authentication: Authentication?
    let accountId: String
    var tokenRefreshManager: TokenRefreshManager?

    private lazy var keychainController = KeychainController(service: .sessions,
                                                             accessGroup: InfoPlistReader.main.keychainAccessGroupIdentifier)

    init(authentication: Authentication?, accountId: String, tokenRefreshManager: TokenRefreshManager?) {
        self.authentication = authentication
        self.accountId = accountId
        self.tokenRefreshManager = tokenRefreshManager
    }

    // MARK: - Adapt:  Called before request to set request headers
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var modifiedRequest = urlRequest

        if (authentication != nil) {
            modifiedRequest.addValue(authentication!.getAuthenticationHeader(), forHTTPHeaderField: "Authorization")
        }

        completion(.success(modifiedRequest))
    }

    // MARK: - Retry: Called when status code is not 200...299 or in failure
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard let response = request.task?.response as? HTTPURLResponse,
              let authenticationSSO = authentication as? AuthenticationSSO,
              validateToRefreshToken(response: response, authenticationSSO: authenticationSSO),
              let tokenRefreshManager else {
            return completion(.doNotRetryWithError(error))
        }

        handleRefreshToken(tokenRefreshManager: tokenRefreshManager) { tokenResponse in
            guard let accessToken = tokenResponse.accessToken else {
                return completion(.doNotRetryWithError(error))
            }

            let newRefreshToken = tokenResponse.refreshToken ?? authenticationSSO.refreshToken
            
            var expireTime: String? = nil
            
            if (tokenResponse.expiresTime != nil) {
                expireTime = CoreUtils.shared.getCurrentDate().adding(seconds: tokenResponse.expiresTime!).convertDateToISO8601String()
            }
            
            self.authentication = AuthenticationSSO(
                type: AuthenticationType.oidc,
                accessToken: accessToken,
                refreshToken: newRefreshToken,
                expireTime: expireTime
            )

            self.keychainController.updateTokenOidc(
                accountId: self.accountId,
                newTokenOidc: TokenOidc(
                    token: accessToken,
                    tokenId: tokenResponse.tokenId,
                    expiredTime: expireTime,
                    refreshToken: newRefreshToken
                )
            )

            return completion(.retry)
        } onFailure: { error in
            return completion(.doNotRetryWithError(error))
        }

    }

    // MARK: - Check the conditions to perform token refresh
    private func validateToRefreshToken(response: HTTPURLResponse, authenticationSSO: AuthenticationSSO) -> Bool {
        return response.statusCode == 401 &&
            !authenticationSSO.refreshToken.isEmpty &&
            authenticationSSO.isExpiredTime(currentDate: CoreUtils.shared.getCurrentDate())
    }

    // MARK: - Handle refresh token to get new token
    private func handleRefreshToken(tokenRefreshManager: TokenRefreshManager,
                                    onSuccess: @escaping (TokenResponse) -> Void,
                                    onFailure: @escaping (Error) -> Void) {
        tokenRefreshManager.handleRefreshAccessToken(onSuccess: onSuccess, onFailure: onFailure)
    }
}
