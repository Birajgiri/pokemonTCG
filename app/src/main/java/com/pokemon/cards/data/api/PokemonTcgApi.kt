package com.pokemon.cards.data.api

import retrofit2.Response
import retrofit2.http.GET
import retrofit2.http.Header
import retrofit2.http.Query

interface PokemonTcgApi {
    
    @GET("v2/cards")
    suspend fun getCards(
        @Header("X-Api-Key") apiKey: String,
        @Query("page") page: Int = 1,
        @Query("pageSize") pageSize: Int = 50
    ): Response<PokemonApiResponse>
    
    @GET("v2/cards")
    suspend fun searchCards(
        @Header("X-Api-Key") apiKey: String,
        @Query("q") query: String,
        @Query("page") page: Int = 1,
        @Query("pageSize") pageSize: Int = 50
    ): Response<PokemonApiResponse>
}
