
import FungibleToken from 0xFUNGIBLETOKENADDRESS
import NonFungibleToken from 0xNONFUNGIBLETOKENADDRESS
import NFTLendingPlace from 0xNFTLENDINGPLACEADDRESS
import FlowToken from 0xFLOWTOKENADDRESS 
import Evolution from 0xEVOLUTIONADDRESS

// This transaction let borrower repay the Flow
transaction(SellerAddress: Address, Uuid: UInt64, RepayAmount: UFix64) {

    let temporaryVault: @FlowToken.Vault
    let collectionRef: &NonFungibleToken.Collection
    prepare(acct: AuthAccount) {

        let vaultRef = acct.borrow<&FlowToken.Vault>(from: /storage/flowTokenVault)
            ?? panic("Could not borrow owner's vault reference")

        self.temporaryVault <- vaultRef.withdraw(amount: RepayAmount) as! @FlowToken.Vault

        self.collectionRef = acct.borrow<&NonFungibleToken.Collection>(from: /storage/EvolutionCollection)
            ?? panic("Could not borrow owner's nft collection reference")
    }

    execute {
        let seller = getAccount(SellerAddress)

        let saleRef = seller.getCapability<&AnyResource{NFTLendingPlace.LendingPublic}>(/public/NFTRent2)
            .borrow()
            ?? panic("Could not borrow seller's sale reference")

        let returnNft <- saleRef.repay(uuid: Uuid,kind: Type<@Evolution.NFT>(), repayAmount: <-self.temporaryVault)

       
    
        self.collectionRef.deposit(token: <- returnNft)

    }
}
 
