contract;

mod errors;

use errors::{MintError, SetError};
use src_20::SRC20;
use src_3::SRC3;
use token::{
    base::{
        _decimals,
        _name,
        _set_decimals,
        _set_name,
        _set_symbol,
        _symbol,
        _total_assets,
        _total_supply,
        SetTokenAttributes,
    },
    mint::{
        _burn,
        _mint,
    },
};
use std::{call_frames::contract_id, hash::Hash, storage::storage_string::*, string::String};

storage {
    total_assets: u64 = 0,
    total_supply: StorageMap<AssetId, u64> = StorageMap {},
    name: StorageMap<AssetId, StorageString> = StorageMap {},
    symbol: StorageMap<AssetId, StorageString> = StorageMap {},
    decimals: StorageMap<AssetId, u8> = StorageMap {},
}

impl SRC20 for Contract {
    /// Returns the total number of individual assets for a contract.
    ///
    /// # Returns
    ///
    /// * [u64] - The number of assets that this contract has minted.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract: ContractId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let total_assets = contract_abi.total_assets().unwrap();
    ///     assert(total_assets != 0);
    /// }
    /// ```
    #[storage(read)]
    fn total_assets() -> u64 {
        _total_assets(storage.total_assets)
    }

    /// Returns the total supply of tokens for an asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the total supply.
    ///
    /// # Returns
    ///
    /// * [Option<u64>] - The total supply of tokens for `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let total_supply = contract_abi.total_supply(asset).unwrap();
    ///     assert(total_supply == 1);
    /// }
    /// ```
    #[storage(read)]
    fn total_supply(asset: AssetId) -> Option<u64> {
        _total_supply(storage.total_supply, asset)
    }

    /// Returns the name of the asset, such as “Ether”.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the name.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The name of `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(contract: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let name = contract_abi.name(asset);
    ///     assert(name.len() != 0);
    /// }
    /// ```
    #[storage(read)]
    fn name(asset: AssetId) -> Option<String> {
        _name(storage.name, asset)
    }
    /// Returns the symbol of the asset, such as “ETH”.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the symbol.
    ///
    /// # Returns
    ///
    /// * [Option<String>] - The symbol of `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(contract: ContractId, asset: AssetId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let symbol = contract_abi.symbol(asset).unwrap();
    ///     assert(symbol.len() != 0);
    /// }
    /// ```
    #[storage(read)]
    fn symbol(asset: AssetId) -> Option<String> {
        _symbol(storage.symbol, asset)
    }
    /// Returns the number of decimals the asset uses.
    ///
    /// # Additional Information
    ///
    /// e.g. 8, means to divide the token amount by 100000000 to get its user interface representation.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to query the decimals.
    ///
    /// # Returns
    ///
    /// * [Option<u8>] - The decimal precision used by `asset`.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src20::SRC20;
    ///
    /// fn foo(contract: ContractId, asset: AssedId) {
    ///     let contract_abi = abi(SRC20, contract);
    ///     let decimals = contract_abi.decimals(asset).unwrap();
    ///     assert(decimals == 8u8);
    /// }
    /// ```
    #[storage(read)]
    fn decimals(asset: AssetId) -> Option<u8> {
        _decimals(storage.decimals, asset)
    }
}

impl SRC3 for Contract {
    /// Mints new tokens using the `sub_id` sub-identifier.
    ///
    /// # Arguments
    ///
    /// * `recipient`: [Identity] - The user to which the newly minted tokens are transferred to.
    /// * `sub_id`: [SubId] - The sub-identifier of the newly minted token.
    /// * `amount`: [u64] - The quantity of tokens to mint.
    ///
    /// # Reverts
    ///
    /// * When more than 100,000,000 tokens have been minted.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `3`
    /// * Writes: `2`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src3::SRC3;
    ///
    /// fn foo(contract: ContractId) {
    ///     let contract_abi = abi(SR3, contract);
    ///     contract_abi.mint(Identity::ContractId(this_contract()), ZERO_B256, 100);
    /// }
    /// ```
    #[storage(read, write)]
    fn mint(recipient: Identity, sub_id: SubId, amount: u64) {
        let asset = AssetId::new(contract_id(), sub_id);
        require(storage.total_supply.get(asset).try_read().unwrap_or(0) + amount < 100_000_000, MintError::MaxMinted);
        let _ = _mint(storage.total_assets, storage.total_supply, recipient, sub_id, amount);
    }
    /// Burns tokens sent with the given `sub_id`.
    ///
    /// # Additional Information
    ///
    /// NOTE: The sha-256 hash of `(ContractId, SubId)` must match the `AssetId` where `ContractId` is the id of
    /// the implementing contract and `SubId` is the given `sub_id` argument.
    ///
    /// # Arguments
    ///
    /// * `sub_id`: [SubId] - The sub-identifier of the token to burn.
    /// * `amount`: [u64] - The quantity of tokens to burn.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    /// * Writes: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use src3::SRC3;
    ///
    /// fn foo(contract: ContractId, asset_id: AssetId) {
    ///     let contract_abi = abi(SR3, contract);
    ///     contract_abi {
    ///         gas: 10000,
    ///         coins: 100,
    ///         asset_id: AssetId,
    ///     }.burn(ZERO_B256, 100);
    /// }
    /// ```
    #[storage(read, write)]
    fn burn(sub_id: SubId, amount: u64) {
        _burn(storage.total_supply, sub_id, amount);
    }
}

impl SetTokenAttributes for Contract {
    /// Sets the name of an asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to set the name.
    /// * `name`: [String] - The name of the asset.
    ///
    /// # Reverts
    ///
    /// * When the name has already been set for an asset.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    /// * Writes: `2`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use token::SetTokenAttributes;
    /// use src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(asset: AssetId) {
    ///     let set_abi = abi(SetTokenAttributes, contract_id);
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let name = String::from_ascii_str("Ether");
    ///     set_abi.set_name(storage.name, asset, name);
    ///     assert(src_20_abi.name(asset) == name);
    /// }
    /// ```
    #[storage(write)]
    fn set_name(asset: AssetId, name: String) {
        require(storage.name.get(asset).read_slice().is_none(), SetError::ValueAlreadySet);
        _set_name(storage.name, asset, name);
    }
    /// Sets the symbol of an asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to set the symbol.
    /// * `symbol`: [String] - The symbol of the asset.
    ///
    /// # Reverts
    ///
    /// * When the symbol has already been set for an asset.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    /// * Writes: `2`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use token::SetTokenAttributes;
    /// use src20::SRC20;
    /// use std::string::String;
    ///
    /// fn foo(asset: AssetId) {
    ///     let set_abi = abi(SetTokenAttributes, contract_id);
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     let symbol = String::from_ascii_str("ETH");
    ///     set_abi.set_symbol(storage.name, asset, symbol);
    ///     assert(src_20_abi.symbol(asset) == symbol);
    /// }
    /// ```
    #[storage(write)]
    fn set_symbol(asset: AssetId, symbol: String) {
        require(storage.symbol.get(asset).read_slice().is_none(), SetError::ValueAlreadySet);
        _set_symbol(storage.symbol, asset, symbol);
    }
    /// Sets the decimals of an asset.
    ///
    /// # Arguments
    ///
    /// * `asset`: [AssetId] - The asset of which to set the decimals.
    /// * `decimal`: [u8] - The decimals of the asset.
    ///
    /// # Reverts
    ///
    /// * When the decimals has already been set for an asset.
    ///
    /// # Number of Storage Accesses
    ///
    /// * Reads: `1`
    /// * Writes: `1`
    ///
    /// # Examples
    ///
    /// ```sway
    /// use token::SetTokenAttributes;
    /// use src20::SRC20;
    ///
    /// fn foo(asset: AssetId) {
    ///     let decimals = 8u8;
    ///     let set_abi = abi(SetTokenAttributes, contract_id);
    ///     let src_20_abi = abi(SRC20, contract_id);
    ///     set_abi.set_decimals(asset, decimals);
    ///     assert(src_20_abi.decimals(asset) == decimals);
    /// }
    /// ```
    #[storage(write)]
    fn set_decimals(asset: AssetId, decimals: u8) {
        require(storage.decimals.get(asset).try_read().is_none(), SetError::ValueAlreadySet);
        _set_decimals(storage.decimals, asset, decimals);
    }
}
