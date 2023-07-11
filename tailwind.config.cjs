const colors = require('tailwindcss/colors');

module.exports = {
	content: [
        './assets/**/*.html'
    ],
	theme: {
		extend: {
            backgroundColor: {
                'dark-1': colors.neutral['900'],
                'dark-2': colors.neutral['800'],
                'dark-3': colors.neutral['700'],
                'dark-4': colors.neutral['600'],
                'dark-5': colors.neutral['500'],
                'dark-6': colors.neutral['400'],
                'light-1': colors.white,
                'light-2': colors.neutral['100'],
                'light-3': colors.neutral['200'],
                'light-4': colors.neutral['300'],
                'light-5': colors.neutral['400'],
                'light-6': colors.neutral['500'],
                'dark-tooltip': colors.neutral['600'],
                'light-tooltip': colors.neutral['600'],
            },
            borderColor: {
                'dark-1': colors.neutral['900'],
                'dark-2': colors.neutral['800'],
                'dark-3': colors.neutral['700'],
                'dark-4': colors.neutral['600'],
                'dark-5': colors.neutral['500'],
                'dark-6': colors.neutral['400'],
                'light-1': colors.white,
                'light-2': colors.neutral['100'],
                'light-3': colors.neutral['200'],
                'light-4': colors.neutral['300'],
                'light-5': colors.neutral['400'],
                'light-6': colors.neutral['500'],
            },
            borderRadius: {
                '4xl': '2rem',
                '5xl': '2.5rem',
            },
            textColor: {
                'dark-1': colors.white,
                'dark-2': colors.neutral['200'],
                'dark-3': colors.neutral['400'],
                'dark-4': colors.neutral['600'],
                'dark-5': colors.neutral['800'],
                'light-1': colors.black,
                'light-2': colors.neutral['900'],
                'light-3': colors.neutral['800'],
                'light-4': colors.neutral['700'],
                'light-5': colors.neutral['600'],
                'dark-tooltip': colors.white,
                'light-tooltip': colors.white,
            },
        },
	},
	plugins: [],
}
