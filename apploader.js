const fs = require('fs')
const util = require('util')
const childProcess = require('child_process')
const path = require('path')

const fileAt100 = "/tmp/100.bin"
const fileAt200 = "/tmp/200.bin"
const loaderAsm = '/tmp/loader.asm'

function exec(command) {
  return new Promise((res, rej) => {
    const p = childProcess.spawn(command, [], {
      stdio: 'inherit',
      shell: '/bin/bash'
    })

    p.on('close', code => code ? rej(new Error(`Exit with code ${code}`)) : res())
  })

}

async function main(...options) {

  const output = options.find(x => x.startsWith('-o'))

  options = options
    .filter(x => !x.startsWith('-o'))
    .map(x => `"${x}"`)

    .join(' ')

    console.log(options)
    console.log(output)

  await exec(`z80asm -r=256 -o"${fileAt100}" -b ${options}`)
  await exec(`z80asm -r=512 -o"${fileAt200}" -b ${options}`)

  const data1 = fs.readFileSync(fileAt100)
  const data2 = fs.readFileSync(fileAt200)

  if (data1.length != data2.length)
    throw new Error("File length are different")

  const hits = []
  for(let i=0; i < data1.length; i++) {
    if (data1[i] !== data2[i])
      hits.push(i - 1)
  }

  const data = new ArrayBuffer(hits.length * 2)
  const view = new DataView(data);

  for(let i = 0; i < hits.length; i++) {
    view.setInt16(i * 2, hits[i], true)
  }

  const fileName = output.slice(2)
  const relocFileName = `/tmp/100.reloc`

  fs.writeFileSync(relocFileName, Buffer.from(data))

  fs.writeFileSync(loaderAsm, fs.readFileSync('loader.asm'))

  await exec(`z80asm -r=256 -o"${fileName}" -b "${loaderAsm}"`)
}

main(...[...process.argv].slice(2)).catch(err => {
  console.log(err.message)
  process.exit(1)
})

