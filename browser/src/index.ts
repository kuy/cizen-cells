import { View } from './view'
import { World, Position, State } from './state'

function main() {
  const view = new View()
  view.onClick((pos: Position) => state.poke(pos))
  const state = new State()
  state.onUpdate((data: World) => view.render(data))
}

document.addEventListener('DOMContentLoaded', main)
