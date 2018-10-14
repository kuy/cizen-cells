import { CubeDimension, CubeColor, PixelView, Point, Point3D, Cube } from 'obelisk.js'
import { World, Position } from './state'

const CUBE_SIZE = 16
const CUBE_HEIGHT = 12

const MAX_VALUE = 5
const colorBy = (value: number): CubeColor => {
  if (value < 0) {
    value = 0
  }
  if (MAX_VALUE < value) {
    value = MAX_VALUE
  }
  const comp = Math.ceil(255 * (MAX_VALUE - value) / MAX_VALUE)
  const rgb = comp * 0x10000 + 255 * 0x100 + comp
  return new CubeColor().getByHorizontalColor(rgb)
}

const dimOf = (value: number): CubeDimension => {
  return new CubeDimension(CUBE_SIZE, CUBE_SIZE, Math.round(CUBE_HEIGHT + value))
}


type ClickHandler = (pos: Position) => any

export class View {
  view: PixelView
  offset: Point
  origin: Point
  callback: ClickHandler | null = null

  constructor() {
    const canvas = document.getElementById('cizen-cells') as HTMLCanvasElement
    this.origin = new Point(300, 200)
    this.view = new PixelView(canvas, this.origin)
    this.offset = new Point(canvas.offsetLeft, canvas.offsetTop)

    canvas.addEventListener('mousedown', this.onDown)
  }

  render(data: World) {
    this.view.clear()
    for (let y = 0; y < data.length; y++) {
      for (let x = 0; x < data[y].length; x++) {
        const cube = new Cube(dimOf(data[y][x]), colorBy(data[y][x]), true)
        const pos = new Point3D(CUBE_SIZE * x, CUBE_SIZE * y, 0)
        this.view.renderObject(cube, pos)
      }
    }
  }

  onClick = (callback: ClickHandler) => {
    this.callback = callback
  }

  private onDown = (ev: MouseEvent) => {
    if (this.callback) {
      const px = ev.pageX - this.offset.x
      const py = ev.pageY - this.offset.y

      const lx = px - this.origin.x
      const ly = py - this.origin.y

      const qx = ly + lx * 0.5
      const qy = ly - lx * 0.5

      const bx = Math.floor(qx / CUBE_SIZE)
      const by = Math.floor(qy / CUBE_SIZE)

      this.callback({ x: bx, y: by })
    }
  }
}
