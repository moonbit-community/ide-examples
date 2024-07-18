// @ts-check

// You can define javascript functions in this file and use them in moonbit
// Check https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API#supported_web_apis to know which apis you can use

/**
 * @type {WebAssembly.Imports}
 */
export default {
  universe: {
    answer: () => 42,
  },
  Math: {
    get_pi: () => Math.PI,
    random: Math.random,
  },
  Runtime: {
    add: (a, b) => a + b,
  },
};
