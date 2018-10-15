# CizenCells

Time-driven two-dimensional asynchronous cellular automaton with Moore neighborhood. Each cell diffuses energy to surroundings. Click to inject energy to the cell. I don't know what I wanted to express with this, but it's funny.

Made with [Cizen](https://gitlab.com/cizen/cizen) + [Obelisk.js](https://github.com/nosir/obelisk.js) + [WebSocket](http://websocket.org/).

![Cizen Cells][5x5input]

## Server

### Prepare

```bash
mix deps.get
```

### Run

```bash
mix run cells.exs
```

## Client (Web)

### Prepare

```bash
cd browser
yarn
```

### Client (Web)

```bash
cd browser
yarn start
```

[5x5input]: https://github.com/kuy/cizen-cells/raw/master/misc/5x5input.gif
