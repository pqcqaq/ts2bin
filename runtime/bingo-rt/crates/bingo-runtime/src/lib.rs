#![deny(unsafe_op_in_unsafe_fn)]

fn abi_version() -> u32 {
    bingo_abi::RUNTIME_ABI_VERSION
}

include!("generated_exports.rs");

#[cfg(test)]
mod tests {
    #[test]
    fn runtime_identity_matches_abi_crate() {
        assert_eq!(super::abi_version(), bingo_abi::RUNTIME_ABI_VERSION);
    }
}
