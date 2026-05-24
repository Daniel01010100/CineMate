import Foundation

enum APISecrets {
    static var tmdbReadAccessToken: String {
        guard let token = Bundle.main.object(forInfoDictionaryKey: "TMDB_READ_ACCESS_TOKEN") as? String,
              !token.isEmpty,
              token != "put_your_tmdb_read_access_token_here"
        else {
            assertionFailure("Missing TMDB_READ_ACCESS_TOKEN, Check Config/Secrets.config")
            return ""
        }
        return token
    }
}
