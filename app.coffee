express = require 'express'
mongoose = require 'mongoose'
config = require './config'

app = express()
db = mongoose.createConnection config.mongoUri

app.use express.static './static'

require('./routes') app

app.listen config.port