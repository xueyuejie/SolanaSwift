//
//  SolanaPublicKey.swift
//  MathWallet5
//
//  Created by xgblin on 2021/8/23.
//

import Foundation
import Base58Swift
import CryptoSwift
import CTweetNacl


public struct SolanaPublicKey {
    
    public static let OWNERPROGRAMID = SolanaPublicKey(base58String: "11111111111111111111111111111111")!
    public static let TOKENPROGRAMID = SolanaPublicKey(base58String: "TokenkegQfeZyiNwAJbNbGKPFXCWuBvf9Ss623VQ5DA")!
    public static let MEMOPROGRAMID = SolanaPublicKey(base58String: "Memo1UhkJRfHyvLMcVucJwxXeuD728EqVDDwQDxFMNo")!
    public static let ASSOCIATEDTOKENPROGRAMID = SolanaPublicKey(base58String: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")!
    public static let SYSVARRENTPUBKEY = SolanaPublicKey(base58String: "SysvarRent111111111111111111111111111111111")!
    public static let OWNERVALIDATIONPROGRAMID = SolanaPublicKey(base58String: "4MNPdKu9wFMvEeZBMt3Eipfs5ovVWTJb31pEXDJAAxX5")!
    
    public var data: Data
    public var address:String {
        return Base58.base58Encode(self.data.bytes)
    }
    
    public init(data: Data) {
        self.data = data
    }
    
    public init?(base58String: String) {
        guard let data = Base58.base58Decode(base58String) else {
            return nil
        }
        self.init(data: Data(data))
    }
    
    public static func newAssociatedToken(pubkey: SolanaPublicKey, mint: SolanaPublicKey) -> SolanaPublicKey? {
        var i = 255
        while i > 0 {
            var data = Data()
            data.appendPubKey(pubkey)
            data.appendPubKey(SolanaPublicKey.TOKENPROGRAMID)
            data.appendPubKey(mint)
            data.appendUInt8(UInt8(i))
            data.appendPubKey(SolanaPublicKey.ASSOCIATEDTOKENPROGRAMID)
            data.appendString("ProgramDerivedAddress")
            let hashdata = data.sha256()
            if (is_on_curve(hashdata.bytes) == 0) {
                return SolanaPublicKey(data: hashdata)
            }
            i = i - 1
        }
        return nil
    }
    

}

extension SolanaPublicKey {
    public static func isValidAddress(_ address: String) -> Bool{
        guard let data = Base58.base58Decode(address) else {
            return false
        }
        guard data.count == 32 else {
            return false
        }
        guard is_on_curve(data) != 0 else {
            return false
        }
        return true
    }
}

extension SolanaPublicKey: Equatable {
    
    public static func == (lhs: SolanaPublicKey, rhs: SolanaPublicKey) -> Bool {
        return lhs.address == rhs.address
    }
    
}

extension SolanaPublicKey: CustomStringConvertible {
    
    public var description: String {
        return self.address
    }
    
}
