package com.pokemon.cards.data.api

data class PokemonApiResponse(
    val data: List<CardData>,
    val page: Int,
    val pageSize: Int,
    val count: Int,
    val totalCount: Int
)

data class CardData(
    val id: String,
    val name: String,
    val supertype: String?,
    val subtypes: List<String>?,
    val hp: String?,
    val types: List<String>?,
    val artist: String?,
    val rarity: String?,
    val series: String?,
    val set: SetInfo?,
    val number: String?,
    val images: CardImages
)

data class SetInfo(
    val id: String,
    val name: String,
    val series: String,
    val printedTotal: Int,
    val total: Int,
    val releaseDate: String
)

data class CardImages(
    val small: String,
    val large: String
)
