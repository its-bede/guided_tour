import resolve from '@rollup/plugin-node-resolve'

export default {
  input: 'src/guided_tour_controller.js',
  output: {
    file: 'dist/guided_tour_controller.js',
    format: 'es'
  },
  external: ['@hotwired/stimulus', 'bootstrap'],
  plugins: [resolve()]
}