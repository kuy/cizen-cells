import { CubeDimension, CubeColor, PixelView, Point, Point3D, Cube } from 'obelisk.js'
import { Stage, StageSize } from './state'

const CUBE_SIZE = 16
const CUBE_DIM = new CubeDimension(CUBE_SIZE, CUBE_SIZE, 12)

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

class View {
  size: StageSize
  view: PixelView

  constructor(size: StageSize) {
    this.size = size

    const canvas = document.getElementById('cizen-cells') as HTMLCanvasElement
    const point = new Point(300, 50)
    this.view = new PixelView(canvas, point)
  }

  update(data: Stage) {
    for (let y = 0; y < data.length; y++) {
      for (let x = 0; x < data[y].length; x++) {
        const cube = new Cube(CUBE_DIM, colorBy(data[y][x]), true)
        const pos = new Point3D(CUBE_SIZE * x, CUBE_SIZE * y, 0)
        this.view.renderObject(cube, pos)
      }
    }
  }
}

export { View }
