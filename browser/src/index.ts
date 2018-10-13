import { View } from './view'
import { Stage, State } from './state'

function main() {
  const size = { width: 5, height: 5 }
  const view = new View(size)
  const state = new State(size)
  state.onUpdate((data: Stage) => view.update(data))
}

document.addEventListener('DOMContentLoaded', main)
