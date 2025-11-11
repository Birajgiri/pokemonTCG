package com.pokemon.cards.ui.adapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.BaseAdapter
import android.widget.ImageView
import android.widget.TextView
import com.bumptech.glide.Glide
import com.pokemon.cards.R
import com.pokemon.cards.data.model.PokemonCard

class PokemonCardAdapter(
    private val context: Context,
    private var cards: List<PokemonCard>
) : BaseAdapter() {

    override fun getCount(): Int = cards.size

    override fun getItem(position: Int): PokemonCard = cards[position]

    override fun getItemId(position: Int): Long = position.toLong()

    override fun getView(position: Int, convertView: View?, parent: ViewGroup?): View {
        val view: View
        val holder: ViewHolder

        if (convertView == null) {
            view = LayoutInflater.from(context).inflate(R.layout.item_card, parent, false)
            holder = ViewHolder(view)
            view.tag = holder
        } else {
            view = convertView
            holder = view.tag as ViewHolder
        }

        val card = getItem(position)
        holder.bind(card)

        return view
    }

    fun updateCards(newCards: List<PokemonCard>) {
        cards = newCards
        notifyDataSetChanged()
    }

    private inner class ViewHolder(view: View) {
        private val cardImage: ImageView = view.findViewById(R.id.cardImage)
        private val cardName: TextView = view.findViewById(R.id.cardName)
        private val cardType: TextView = view.findViewById(R.id.cardType)
        private val cardSet: TextView = view.findViewById(R.id.cardSet)

        fun bind(card: PokemonCard) {
            cardName.text = card.name
            
            val typeText = buildString {
                card.supertype?.let { append(it) }
                card.subtype?.let { 
                    if (isNotEmpty()) append(" - ")
                    append(it)
                }
            }
            cardType.text = typeText.ifEmpty { "Unknown Type" }
            
            cardSet.text = card.set ?: "Unknown Set"

            Glide.with(context)
                .load(card.imageUrl)
                .placeholder(android.R.drawable.ic_menu_gallery)
                .error(android.R.drawable.ic_menu_report_image)
                .into(cardImage)
        }
    }
}
