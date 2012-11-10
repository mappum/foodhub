mongoose = require 'mongoose'

schema = new mongoose.Schema
	username: 
		type: String
		index: true
		unique: true
	avatar: String
	email: String
	password:
		hash: String
		salt: String

module.exports = new mongoose.Model schema	