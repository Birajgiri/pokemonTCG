package com.pokemon.cards.ui.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.viewModelScope
import com.pokemon.cards.data.model.PokemonCard
import com.pokemon.cards.data.repository.PokemonRepository
import kotlinx.coroutines.launch

class PokemonViewModel(application: Application) : AndroidViewModel(application) {
    
    private val repository = PokemonRepository(application)
    
    private val _cards = MutableLiveData<List<PokemonCard>>()
    val cards: LiveData<List<PokemonCard>> = _cards
    
    private val _loading = MutableLiveData<Boolean>()
    val loading: LiveData<Boolean> = _loading
    
    private val _error = MutableLiveData<String?>()
    val error: LiveData<String?> = _error
    
    init {
        loadCards()
    }
    
    fun loadCards() {
        _loading.value = true
        _error.value = null
        
        viewModelScope.launch {
            // First, try to load from database
            val cachedCards = repository.getCardsFromDatabase()
            if (cachedCards.isNotEmpty()) {
                _cards.value = cachedCards
                _loading.value = false
            }
            
            // Then fetch from API
            val result = repository.fetchAndSaveCards()
            result.onSuccess { cards ->
                _cards.value = cards
                _loading.value = false
            }.onFailure { exception ->
                // If we have cached cards, keep showing them
                if (cachedCards.isEmpty()) {
                    _error.value = exception.message ?: "Unknown error occurred"
                }
                _loading.value = false
            }
        }
    }
    
    fun getCardById(id: String): PokemonCard? {
        return repository.getCardById(id)
    }
}
