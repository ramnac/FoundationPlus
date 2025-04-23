//
//  KeychainWrapper.swift
//  iOSNetwork
//
//  Created by Ram on 05/03/2025.
//
// Apple's article on secure store user's data:
// https://developer.apple.com/documentation/security/keychain_services/keychain_items/using_the_keychain_to_manage_user_secrets


import Foundation
import Security

/// A type-safe wrapper around Keychain Services API for secure storage of sensitive data
public enum KeychainWrapper {
    
    /// Error types that can occur during Keychain operations
    public enum KeychainError: Error, LocalizedError, Sendable {
        case encodingFailed
        case unexpectedStatus(OSStatus)
        case itemNotFound
        
        public var errorDescription: String? {
            switch self {
            case .encodingFailed:
                return "Failed to encode string to data"
            case .unexpectedStatus(let status):
                return "Unexpected keychain error: \(status.description)"
            case .itemNotFound:
                return "Item not found in keychain"
            }
        }
    }
    
    /// Removes all generic password keychain items for the app
    /// - Returns: Result indicating success or the specific error that occurred
    @discardableResult
    public static func resetKeyChainData() -> Result<Void, KeychainError> {
        let osStatus = removeAllKeys()
        switch osStatus {
        case errSecSuccess:
            AppLogger.network("✅ Keychain data has been successfully reset")
            return .success(())
        case errSecItemNotFound:
            AppLogger.network("✅ No keychain data found. All clean")
            return .success(())
        default:
            let error = KeychainError.unexpectedStatus(osStatus)
            AppLogger.network("❌ Error resetting keychain data: \(error.errorDescription ?? "Unknown error")")
            return .failure(error)
        }
    }
    
    /// Adds a string value to the keychain for the given key
    /// - Parameters:
    ///   - key: The key to store the value under
    ///   - value: The string value to store
    /// - Returns: Result indicating success or the specific error that occurred
    @discardableResult
    public static func addItem(key: String, value: String) -> Result<Void, KeychainError> {
        guard let data = value.data(using: .utf8) else {
            return .failure(.encodingFailed)
        }
        
        do {
            var keychainQuery = try setupKeychainQuery(key: key)
            keychainQuery[kSecValueData as String] = data
            
            let status = SecItemAdd(keychainQuery as CFDictionary, nil)
            switch status {
            case errSecSuccess:
                AppLogger.network("⚙️ Value saved in Keychain for key: \(key)")
                return .success(())
            case errSecDuplicateItem:
                return updateItem(key: key, value: data)
            default:
                return .failure(.unexpectedStatus(status))
            }
        } catch {
            return .failure(error as? KeychainError ?? .unexpectedStatus(errSecParam))
        }
    }
    
    /// Retrieves a string value from the keychain for the given key
    /// - Parameter key: The key to retrieve the value for
    /// - Returns: Result containing the retrieved string or the specific error that occurred
    public static func getItem(key: String) -> Result<String, KeychainError> {
        do {
            var keychainQuery = try setupKeychainQuery(key: key)
            keychainQuery[kSecMatchLimit as String] = kSecMatchLimitOne
            keychainQuery[kSecReturnData as String] = kCFBooleanTrue
            
            var result: AnyObject?
            let status = SecItemCopyMatching(keychainQuery as CFDictionary, &result)
            
            switch status {
            case errSecSuccess:
                guard let data = result as? Data, let string = String(data: data, encoding: .utf8) else {
                    return .failure(.encodingFailed)
                }
                return .success(string)
            case errSecItemNotFound:
                return .failure(.itemNotFound)
            default:
                return .failure(.unexpectedStatus(status))
            }
        } catch {
            return .failure(error as? KeychainError ?? .unexpectedStatus(errSecParam))
        }
    }
    
    /// Backward compatibility method that returns optional string directly
    /// - Parameter key: The key to retrieve the value for
    /// - Returns: The string value if found, nil otherwise
    public static func getItem(key: String) -> String? {
        switch getItem(key: key) as Result {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }
    
    /// Removes an item from the keychain for the given key
    /// - Parameter key: The key to remove
    /// - Returns: Result indicating success or the specific error that occurred
    @discardableResult
    public static func removeItem(key: String) -> Result<Void, KeychainError> {
        do {
            let keychainQuery = try setupKeychainQuery(key: key)
            let status = SecItemDelete(keychainQuery as CFDictionary)
            
            switch status {
            case errSecSuccess:
                return .success(())
            case errSecItemNotFound:
                return .failure(.itemNotFound)
            default:
                return .failure(.unexpectedStatus(status))
            }
        } catch {
            return .failure(error as? KeychainError ?? .unexpectedStatus(errSecParam))
        }
    }
    
    // MARK: - Private Methods
    
    private static func removeAllKeys() -> OSStatus {
        let keychainQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword]
        return SecItemDelete(keychainQuery as CFDictionary)
    }
    
    private static func updateItem(key: String, value: Data) -> Result<Void, KeychainError> {
        do {
            let keychainQuery = try setupKeychainQuery(key: key)
            let updateDictionary = [kSecValueData as String: value]
            let status = SecItemUpdate(keychainQuery as CFDictionary, updateDictionary as CFDictionary)
            
            switch status {
            case errSecSuccess:
                AppLogger.network("⚙️ The value in Keychain for key \(key) is updated")
                return .success(())
            default:
                return .failure(.unexpectedStatus(status))
            }
        } catch {
            return .failure(error as? KeychainError ?? .unexpectedStatus(errSecParam))
        }
    }
    
    private static func setupKeychainQuery(key: String) throws -> [String: Any] {
        guard let encodedKey = key.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }
        
        // Add service name to make key more unique and secure
        let bundleID = Bundle.main.bundleIdentifier ?? "com.workfast.app"
        
        let keychainQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: encodedKey,
            kSecAttrService as String: bundleID,
            // Add additional security attributes
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]
        
        return keychainQuery
    }
}
