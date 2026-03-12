export default {
  "backend/**/*.py": [
    () => "make server-lint-fix",
    () => "make server-format",
  ],
  "frontend/**/*.{ts,tsx,js,mjs}": () => "pnpm --dir frontend lint:fix",
  "frontend/**/*.{ts,tsx,js,mjs,json,css,md}": () => "pnpm --dir frontend format",
};
