mongoose = require 'mongoose'

Author = new mongoose.Schema
	userid: ObjectId
	username: String
	avatar: String

Subrecipe = new mongoose.Schema
	url: String
	author: Author
	title: String

schema = new mongoose.Schema
	title: String
	author: 
		type: Author
		index: true
	description: String
	picture: String
	instructions: [String]
	ingredients: [String]
	id: ObjectId
	url: 
		type: String
		index: true
		unique: true
	origin: Subrecipe
	forks: [Subrecipe]




module.exports = new mongoose.Model schema