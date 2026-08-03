export {};

async function collect() {
  const values = await Array.fromAsync(
    [Promise.resolve(1), Promise.resolve(2)],
    (value) => value * 2,
  );

  const sorted = values.toSorted((a, b) => a - b);
  const changed = sorted.with(0, 10);
  return changed;
}

const bytes = Uint8Array.fromHex("48656c6c6f");
const encoded = bytes.toBase64({ alphabet: "base64url", omitPadding: true });

const buffer = new ArrayBuffer(8, { maxByteLength: 64 });
buffer.resize(16);
const view = new DataView(buffer);
view.setFloat16(0, Math.f16round(1.5), true);

void [collect, encoded, view.getFloat16(0, true)];
