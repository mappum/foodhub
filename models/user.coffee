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

module.exports = mongoose.model 'User', schema	