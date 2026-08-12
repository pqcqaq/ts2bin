#include "bingo_abi.h"

#include <pthread.h>
#include <stdint.h>
#include <string.h>

enum { REFERENCE_OFFSET = sizeof(BingoObjectHeaderV1) };

static const uint32_t POINTER_OFFSETS[] = {REFERENCE_OFFSET};
static const BingoTraceDescriptorV1 TRACE = {
    .schema_version = BINGO_OBJECT_LAYOUT_SCHEMA_VERSION,
    .flags = 0,
    .object_size = sizeof(BingoObjectHeaderV1) + sizeof(void *),
    .pointer_count = 1,
    .pointer_map_words = 0,
    .pointer_offsets = POINTER_OFFSETS,
    .trace_callback = NULL,
};
static const BingoShapeDescriptorV1 SHAPE = {
    .schema_version = BINGO_OBJECT_LAYOUT_SCHEMA_VERSION,
    .flags = 0,
    .object_size = sizeof(BingoObjectHeaderV1) + sizeof(void *),
    .object_align = _Alignof(void *),
    .property_count = 1,
    .presence_word_count = 0,
    .properties = NULL,
    .trace = &TRACE,
};

static int expect_status(uint32_t got, uint32_t want) {
    return got == want ? 0 : 1;
}

static void store_reference(BingoObjectHeaderV1 *owner, BingoObjectHeaderV1 *value) {
    memcpy((unsigned char *)owner + REFERENCE_OFFSET, &value, sizeof(value));
}

static void *wrong_thread_probe(void *unused) {
    BingoGcStatsV1 stats;
    (void)unused;
    return (void *)(uintptr_t)bingo_gc_stats_v1(&stats);
}

int main(void) {
    BingoObjectHeaderV1 *left = NULL;
    BingoObjectHeaderV1 *right = NULL;
    BingoObjectHeaderV1 *dead = NULL;
    BingoObjectHeaderV1 *reloaded = NULL;
    BingoObjectHeaderV1 *slots[2] = {NULL, NULL};
    BingoGcFrameV1 frame = {NULL, slots, 2, 0, 0};
    BingoGcFrameV1 nested = {NULL, NULL, 0, 0, 0};
    BingoGcStatsV1 stats;
    BingoObjectHeaderV1 foreign = {0};
    BingoTraceDescriptorV1 malformed_trace = TRACE;
    BingoShapeDescriptorV1 malformed_shape = SHAPE;
    pthread_t thread;
    void *thread_result = NULL;

    if (expect_status(bingo_gc_heap_reset_v1(), BINGO_GC_OK) ||
        pthread_create(&thread, NULL, wrong_thread_probe, NULL) != 0 ||
        pthread_join(thread, &thread_result) != 0 ||
        (uintptr_t)thread_result != BINGO_GC_WRONG_THREAD) {
        return 10;
    }

    malformed_trace.object_size++;
    malformed_shape.trace = &malformed_trace;
    if (expect_status(bingo_gc_alloc_v1(&malformed_shape, &left), BINGO_GC_INVALID_ARGUMENT) ||
        left != NULL) {
        return 11;
    }

    if (expect_status(bingo_gc_alloc_v1(&SHAPE, &left), BINGO_GC_OK) || left == NULL ||
        expect_status(bingo_gc_alloc_v1(&SHAPE, &right), BINGO_GC_OK) || right == NULL ||
        expect_status(bingo_gc_alloc_v1(&SHAPE, &dead), BINGO_GC_OK) || dead == NULL ||
        left->descriptor != &SHAPE || left->size_bytes != SHAPE.object_size || left->gc_word != 0) {
        return 12;
    }
    store_reference(left, right);
    store_reference(right, left);
    if (expect_status(bingo_gc_write_barrier_v1(left, REFERENCE_OFFSET, right), BINGO_GC_OK) ||
        expect_status(bingo_gc_write_barrier_v1(left, REFERENCE_OFFSET + sizeof(void *), right),
                      BINGO_GC_INVALID_ARGUMENT) ||
        expect_status(bingo_gc_root_store_v1(&frame, 0, &foreign), BINGO_GC_FRAME_STATE)) {
        return 13;
    }

    if (expect_status(bingo_gc_frame_link_v1(&frame), BINGO_GC_OK) ||
        expect_status(bingo_gc_heap_reset_v1(), BINGO_GC_FRAME_STATE) ||
        expect_status(bingo_gc_root_store_v1(&frame, 0, &foreign), BINGO_GC_INVALID_ARGUMENT) ||
        expect_status(bingo_gc_root_store_v1(&frame, 0, left), BINGO_GC_OK) ||
        expect_status(bingo_gc_root_store_v1(&frame, 1, dead), BINGO_GC_OK) ||
        expect_status(bingo_gc_root_publish_v1(&frame, 4), BINGO_GC_INVALID_ARGUMENT) ||
        expect_status(bingo_gc_root_publish_v1(&frame, 1), BINGO_GC_OK) ||
        expect_status(bingo_gc_safepoint_v1(), BINGO_GC_OK)) {
        return 14;
    }
    if (expect_status(bingo_gc_stats_v1(&stats), BINGO_GC_OK) || stats.allocated_objects != 2 ||
        stats.collections != 1 || expect_status(bingo_gc_root_reload_v1(&frame, 0, &reloaded), BINGO_GC_OK) ||
        reloaded != left || left->gc_word != 0 || right->gc_word != 0) {
        return 15;
    }

    if (expect_status(bingo_gc_frame_link_v1(&nested), BINGO_GC_OK)) {
        return 16;
    }
    nested.previous = &nested;
    if (expect_status(bingo_gc_collect_v1(), BINGO_GC_FRAME_STATE)) {
        return 16;
    }
    nested.previous = &frame;
    if (
        expect_status(bingo_gc_collect_v1(), BINGO_GC_OK) ||
        expect_status(bingo_gc_stats_v1(&stats), BINGO_GC_OK) || stats.allocated_objects != 2 ||
        stats.collections != 2 ||
        expect_status(bingo_gc_frame_unlink_v1(&frame), BINGO_GC_FRAME_STATE) ||
        expect_status(bingo_gc_frame_unlink_v1(&nested), BINGO_GC_OK) ||
        expect_status(bingo_gc_root_clear_v1(&frame, 0), BINGO_GC_OK) ||
        expect_status(bingo_gc_root_clear_v1(&frame, 1), BINGO_GC_OK) ||
        expect_status(bingo_gc_root_publish_v1(&frame, 0), BINGO_GC_OK) ||
        expect_status(bingo_gc_collect_v1(), BINGO_GC_OK) ||
        expect_status(bingo_gc_stats_v1(&stats), BINGO_GC_OK) || stats.allocated_objects != 0 ||
        stats.allocated_bytes != 0 || stats.collections != 3 ||
        expect_status(bingo_gc_frame_unlink_v1(&frame), BINGO_GC_OK) ||
        expect_status(bingo_gc_heap_reset_v1(), BINGO_GC_OK)) {
        return 17;
    }
    return 0;
}
