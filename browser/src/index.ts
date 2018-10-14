import { View } from './view'
import { World, State } from './state'

function main() {
  const view = new View()
  const state = new State()
  state.onUpdate((data: World) => view.render(data))
}

document.addEventListener('DOMContentLoaded', main)
