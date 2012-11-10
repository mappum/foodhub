mongoose = require 'mongoose'

schema = new mongoose.Schema
	username: 
		type: String
		index: true
		unique: true
	avatar: String
	email: String
	date: 
		type: Date
		default: Date.now
	password:
		hash: String
		salt: String

module.exports = new mongoose.Model schema	