// Tampilan Landing Page sementara
import 'package:flutter/material.dart';

class ReviewLandingPage extends StatelessWidget {
  const ReviewLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Review Pertandingan"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // HEADER ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Review Pertandingan",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                DropdownButton<String>(
                  value: "-review_count",
                  items: const [
                    DropdownMenuItem(
                      value: "-review_count",
                      child: Text("Paling Populer"),
                    ),
                    DropdownMenuItem(
                      value: "highest_rating",
                      child: Text("Rating Tertinggi"),
                    ),
                    DropdownMenuItem(
                      value: "lowest_rating",
                      child: Text("Rating Terendah"),
                    ),
                  ],
                  onChanged: (value) {
                    // TODO: integrate backend/controller
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // GRID
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1, // mobile-friendly
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 6, // TODO: ganti dengan event_list.length
                itemBuilder: (context, index) {
                  return _buildEventCard(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 6,
            offset: const Offset(0, 2),
            color: Colors.black.withOpacity(0.08),
          ),
        ],
      ),
      child: Column(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              "https://picsum.photos/300", // TODO: event.image_url
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),

          // CONTENT
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Team A vs Team B",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 4),

                // RATING
                Row(
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text("4.5 (120 review)"),
                  ],
                ),

                const SizedBox(height: 8),

                const Text(
                  "Kategori — Lokasi",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                const Text(
                  "12 Jan 2025 | 19:30",
                  style: TextStyle(
                    color: Color(0xff003399),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(40),
              ),
              onPressed: () {},
              child: const Text("Lihat Review"),
            ),
          )
        ],
      ),
    );
  }
}
