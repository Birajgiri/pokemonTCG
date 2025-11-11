package com.pokemon.cards.data.repository

import android.content.Context
import com.pokemon.cards.data.api.CardData
import com.pokemon.cards.data.api.RetrofitClient
import com.pokemon.cards.data.database.PokemonDatabaseHelper
import com.pokemon.cards.data.model.PokemonCard
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class PokemonRepository(context: Context) {
    
    private val database = PokemonDatabaseHelper(context)
    private val api = RetrofitClient.api
    
    suspend fun fetchAndSaveCards(): Result<List<PokemonCard>> = withContext(Dispatchers.IO) {
        try {
            val response = api.getCards(
                apiKey = RetrofitClient.API_KEY,
                page = 1,
                pageSize = 50
            )
            
            if (response.isSuccessful) {
                val apiCards = response.body()?.data ?: emptyList()
                val pokemonCards = apiCards.map { it.toPokemonCard() }
                
                // Save to database
                database.insertCards(pokemonCards)
                
                Result.success(pokemonCards)
            } else {
                Result.failure(Exception("API Error: ${response.code()} - ${response.message()}"))
            }
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    fun getCardsFromDatabase(): List<PokemonCard> {
        return database.getAllCards()
    }
    
    fun getCardById(id: String): PokemonCard? {
        return database.getCardById(id)
    }
    
    private fun CardData.toPokemonCard(): PokemonCard {
        return PokemonCard(
            id = this.id,
            name = this.name,
            imageUrl = this.images.small,
            imageUrlHiRes = this.images.large,
            supertype = this.supertype,
            subtype = this.subtypes?.firstOrNull(),
            hp = this.hp,
            artist = this.artist,
            rarity = this.rarity,
            series = this.series,
            set = this.set?.name,
            setCode = this.set?.id,
            number = this.number
        )
    }
}
