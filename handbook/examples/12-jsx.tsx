export {};

declare global {
  namespace JSX {
    interface Element {
      readonly __brand: "element";
    }

    interface IntrinsicElements {
      button: { onClick?: () => void; children?: string };
    }
  }
}

type ButtonProps = {
  label: string;
  onClick?: () => void;
};

function Button(_props: ButtonProps): JSX.Element {
  return <button>Save</button>;
}

const view = <Button label="Save" onClick={() => undefined} />;
// @ts-expect-error label 是必选属性
const invalid = <Button />;
void [view, invalid];
