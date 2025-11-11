package com.pokemon.cards.ui

import android.os.Bundle
import android.widget.ImageView
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import com.bumptech.glide.Glide
import com.pokemon.cards.R
import com.pokemon.cards.data.model.PokemonCard
import com.pokemon.cards.ui.viewmodel.PokemonViewModel

class CardDetailActivity : AppCompatActivity() {

    private lateinit var viewModel: PokemonViewModel
    private lateinit var cardImageLarge: ImageView
    private lateinit var cardNameDetail: TextView
    private lateinit var cardTypeDetail: TextView
    private lateinit var cardHpDetail: TextView
    private lateinit var cardRarityDetail: TextView
    private lateinit var cardSetDetail: TextView
    private lateinit var cardArtistDetail: TextView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_card_detail)

        supportActionBar?.setDisplayHomeAsUpEnabled(true)
        supportActionBar?.title = getString(R.string.card_detail)

        initViews()
        setupViewModel()
        loadCardDetails()
    }

    private fun initViews() {
        cardImageLarge = findViewById(R.id.cardImageLarge)
        cardNameDetail = findViewById(R.id.cardNameDetail)
        cardTypeDetail = findViewById(R.id.cardTypeDetail)
        cardHpDetail = findViewById(R.id.cardHpDetail)
        cardRarityDetail = findViewById(R.id.cardRarityDetail)
        cardSetDetail = findViewById(R.id.cardSetDetail)
        cardArtistDetail = findViewById(R.id.cardArtistDetail)
    }

    private fun setupViewModel() {
        viewModel = ViewModelProvider(this)[PokemonViewModel::class.java]
    }

    private fun loadCardDetails() {
        val cardId = intent.getStringExtra("CARD_ID") ?: return
        val card = viewModel.getCardById(cardId) ?: return

        displayCard(card)
    }

    private fun displayCard(card: PokemonCard) {
        cardNameDetail.text = card.name

        // Load high-res image if available, otherwise use regular image
        val imageUrl = card.imageUrlHiRes ?: card.imageUrl
        Glide.with(this)
            .load(imageUrl)
            .placeholder(android.R.drawable.ic_menu_gallery)
            .error(android.R.drawable.ic_menu_report_image)
            .into(cardImageLarge)

        // Type
        val typeText = buildString {
            append("Type: ")
            card.supertype?.let { append(it) }
            card.subtype?.let {
                if (card.supertype != null) append(" - ")
                append(it)
            }
        }
        cardTypeDetail.text = typeText

        // HP
        cardHpDetail.text = if (card.hp != null) {
            "HP: ${card.hp}"
        } else {
            "HP: N/A"
        }

        // Rarity
        cardRarityDetail.text = "Rarity: ${card.rarity ?: "Unknown"}"

        // Set
        val setText = buildString {
            append("Set: ")
            card.set?.let { append(it) }
            card.number?.let {
                if (card.set != null) append(" - ")
                append("#$it")
            }
        }
        cardSetDetail.text = setText

        // Artist
        cardArtistDetail.text = "Artist: ${card.artist ?: "Unknown"}"
    }

    override fun onSupportNavigateUp(): Boolean {
        onBackPressed()
        return true
    }
}
