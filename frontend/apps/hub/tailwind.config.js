/** @type {import('tailwindcss').Config} */
module.exports = {
	content: [
		"./src/**/components/**/*.{ts,tsx}",
		"./src/layouts/**/*.{ts,tsx}",
		"./src/forms/**/*.{ts,tsx}",
		"./src/lib/**/*.{ts,tsx}",
		"./src/**/hooks/**/*.{ts,tsx}",
		"./src/**/forms/**/*.{ts,tsx}",
		"./src/**/layouts/**/*.{ts,tsx}",
		"./src/**/views/**/*.{ts,tsx}",
		"./src/**/routes/**/*.{ts,tsx}",
		"../../../node_modules/@rivet-gg/components/src/**/*.{ts,tsx}",
	],
	presets: [require("@rivet-gg/components/tailwind-base")],
};
