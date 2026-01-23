import standard from "@eslint/js";

export default [
  standard.configs.recommended,
  {
    files: ["**/*.js", "**/*.mjs"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: {
        process: "readonly",
        console: "readonly",
        Buffer: "readonly"
      }
    },
    rules: {
      // You can override/add rules here if needed
    }
  }
];
