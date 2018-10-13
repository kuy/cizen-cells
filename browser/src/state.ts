export type StageSize = {
  width: number,  // column number of cells
  height: number, // row number of cells
}

export type CellData = {
  x: number,
  y: number,
  value: number,
}

type UpdateHandler = (data: Stage) => any

export type Stage = number[][]

export const range = (n: number): number[] => {
  const list = []
  for (let i = 0; i < n; i++) {
    list.push(i)
  }
  return list
}

export class State {
  ws: WebSocket
  callback: UpdateHandler | null = null
  ready: boolean = false
  store: Stage

  constructor(size: StageSize) {
    this.store = [] as number[][]
    for (const _ of range(size.height)) {
      const row = [] as number[]
      this.store.push(row)
      for (const _ of range(size.width)) {
        row.push(0)
      }
    }

    this.ws = new WebSocket('ws://localhost:8080')
    this.ws.onopen = this.onOpen
    this.ws.onmessage = this.onMessage
    this.ws.onerror = this.onError
  }

  onUpdate = (callback: UpdateHandler) => {
    this.callback = callback
  }

  private onOpen = () => {
    this.ready = true
  }

  private onMessage = (ev: MessageEvent) => {
    if (this.callback) {
      const data = JSON.parse(ev.data) as CellData
      this.update(data)
      this.callback(this.store)
    }
  }

  private onError = (ev: Event) => {
    console.log(ev)
  }

  private update = (data: CellData) => {
    this.store[data.y][data.x] = data.value
  }
}
