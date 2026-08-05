#[unsafe(no_mangle)]
pub extern "C" fn bingo_rt_v1_smoke_add(left: i32, right: i32) -> i32 {
    left + right
}
