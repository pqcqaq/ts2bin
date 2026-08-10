#![forbid(unsafe_code)]

include!("generated.rs");

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn schema_and_runtime_abi_are_versioned() {
        assert_eq!(ABI_SCHEMA_VERSION, 1);
        assert_eq!(RUNTIME_ABI_VERSION, 1);
    }
}
