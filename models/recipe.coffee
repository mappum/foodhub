mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

Author =
	userId: ObjectId
	username: String
	avatar: String

Subrecipe =
	id: String
	author: String
	title: String

schema = new Schema
	title: String
	author: String 
	description: String
	picture: String
	instructions: [String]
	ingredients: [String]
	origin: Subrecipe
	forks: [Subrecipe]
	date:
		type: Date
		default: Date.now

module.exports = mongoose.model 'Recipe', schema
