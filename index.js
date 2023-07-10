const express = require('express');
const mongoose = require('mongoose');

const app = express();

// Connect to MongoDB
mongoose
  .connect('mongodb://mongodb-container:27017/mydatabase', { useNewUrlParser: true })
  .then(() => {
    console.log('MongoDB Connected');
    insertInitialData(); // Insert initial data after successful connection
  })
  .catch(err => console.log(err));

const FruitSchema = new mongoose.Schema({
  name: String,
  qty: Number,
  rating: Number
});

const Fruit = mongoose.model('Fruit', FruitSchema);

function insertInitialData() {
  const fruits = [
    { name: 'apples', qty: 5, rating: 3 },
    { name: 'bananas', qty: 7, rating: 1 },
    { name: 'oranges', qty: 6, rating: 2 },
    { name: 'avocados', qty: 3, rating: 5 }
  ];

  Fruit.insertMany(fruits)
    .then(() => console.log('Initial data inserted'))
    .catch(err => console.error('Error inserting initial data:', err));
}

app.get('/', (req, res) => {
  Fruit.findOne({ name: 'apples' })
    .then(fruit => {
      if (!fruit) {
        throw new Error('No fruit found');
      }
      const message = `Hello, World! Number of apples: ${fruit.qty}`;
      res.send(message);
    })
    .catch(err => {
      console.error('Error retrieving fruit:', err);
      res.status(500).send('Error retrieving fruit from the database');
    });
});

const port = 3000;

app.listen(port, () => console.log('Server running...'));
