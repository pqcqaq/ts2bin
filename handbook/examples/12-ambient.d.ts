declare const APP_VERSION: string;

declare module "legacy-parser" {
  export interface Options {
    strict?: boolean;
  }

  export function parse(input: string, options?: Options): unknown;
}
