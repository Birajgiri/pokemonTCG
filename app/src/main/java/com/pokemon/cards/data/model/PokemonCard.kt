package com.pokemon.cards.data.model

data class PokemonCard(
    val id: String,
    val name: String,
    val imageUrl: String,
    val imageUrlHiRes: String?,
    val supertype: String?,
    val subtype: String?,
    val hp: String?,
    val artist: String?,
    val rarity: String?,
    val series: String?,
    val set: String?,
    val setCode: String?,
    val number: String?
)
