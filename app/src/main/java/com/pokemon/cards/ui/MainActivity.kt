package com.pokemon.cards.ui

import android.content.Intent
import android.os.Bundle
import android.view.View
import android.widget.Button
import android.widget.ListView
import android.widget.ProgressBar
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import com.pokemon.cards.R
import com.pokemon.cards.ui.adapter.PokemonCardAdapter
import com.pokemon.cards.ui.viewmodel.PokemonViewModel

class MainActivity : AppCompatActivity() {

    private lateinit var viewModel: PokemonViewModel
    private lateinit var adapter: PokemonCardAdapter
    private lateinit var listView: ListView
    private lateinit var progressBar: ProgressBar
    private lateinit var errorLayout: View
    private lateinit var errorText: TextView
    private lateinit var retryButton: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        initViews()
        setupViewModel()
        setupListView()
        observeViewModel()
    }

    private fun initViews() {
        listView = findViewById(R.id.listView)
        progressBar = findViewById(R.id.progressBar)
        errorLayout = findViewById(R.id.errorLayout)
        errorText = findViewById(R.id.errorText)
        retryButton = findViewById(R.id.retryButton)

        retryButton.setOnClickListener {
            viewModel.loadCards()
        }
    }

    private fun setupViewModel() {
        viewModel = ViewModelProvider(this)[PokemonViewModel::class.java]
    }

    private fun setupListView() {
        adapter = PokemonCardAdapter(this, emptyList())
        listView.adapter = adapter

        listView.setOnItemClickListener { _, _, position, _ ->
            val card = adapter.getItem(position)
            val intent = Intent(this, CardDetailActivity::class.java).apply {
                putExtra("CARD_ID", card.id)
            }
            startActivity(intent)
        }
    }

    private fun observeViewModel() {
        viewModel.cards.observe(this) { cards ->
            adapter.updateCards(cards)
        }

        viewModel.loading.observe(this) { isLoading ->
            progressBar.visibility = if (isLoading) View.VISIBLE else View.GONE
            if (isLoading) {
                errorLayout.visibility = View.GONE
            }
        }

        viewModel.error.observe(this) { error ->
            if (error != null) {
                errorText.text = error
                errorLayout.visibility = View.VISIBLE
                listView.visibility = View.GONE
            } else {
                errorLayout.visibility = View.GONE
                listView.visibility = View.VISIBLE
            }
        }
    }
}
