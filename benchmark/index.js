const crypto = require('crypto')
const duration = 15

function benchmark() {
    const rates = Array(duration + 1).fill(0)
    const start = process.hrtime()

    while (process.hrtime(start)[0] < duration) {
        crypto.pbkdf2Sync(crypto.randomBytes(16), crypto.randomBytes(16), 15000, 32, 'sha256')
        rates[process.hrtime(start)[0]] += 1
    }

    console.log(JSON.stringify(rates.slice(0, duration)))
}

exports.handler = benchmark

if (require.main === module) {
    benchmark()
}
