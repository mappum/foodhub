mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.Types.ObjectId

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
	numforks: Number
	date:
		type: Date
		default: Date.now

module.exports = mongoose.model 'Recipe', schema
