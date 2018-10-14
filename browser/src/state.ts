export type World = number[][]

type UpdateHandler = (data: World) => any

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

  constructor() {
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
      this.callback(JSON.parse(ev.data) as World)
    }
  }

  private onError = (ev: Event) => {
    console.log(ev)
  }
}
