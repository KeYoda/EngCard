import pandas as pd
import numpy as np
import tensorflow as tf
from sklearn.preprocessing import LabelEncoder
from keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
import nltk
nltk.download('punkt')

# 1. CSV dosyasını oku
df = pd.read_csv("chatbot_data.csv")

# 2. Giriş ve çıkış cümleleri al
inputs = df['input'].values
outputs = df['output'].values

# 3. Cevapları label encoder ile sayıya çevir
lbl_encoder = LabelEncoder()
outputs_encoded = lbl_encoder.fit_transform(outputs)

# 4. Giriş cümlelerini token haline getir
tokenizer = Tokenizer(num_words=2000, oov_token="<OOV>")
tokenizer.fit_on_texts(inputs)
input_sequences = tokenizer.texts_to_sequences(inputs)
padded_inputs = pad_sequences(input_sequences, padding='post')

# 5. Modeli oluştur
model = tf.keras.Sequential([
    tf.keras.layers.Embedding(input_dim=2000, output_dim=16, input_length=padded_inputs.shape[1]),
    tf.keras.layers.GlobalAveragePooling1D(),
    tf.keras.layers.Dense(16, activation='relu'),
    tf.keras.layers.Dense(len(np.unique(outputs_encoded)), activation='softmax')
])

model.compile(loss='sparse_categorical_crossentropy', optimizer='adam', metrics=['accuracy'])

# 6. Modeli eğit
model.fit(padded_inputs, outputs_encoded, epochs=500)

# 7. Modeli kaydet
model.save("chatbot_model.h5")
def predict_reply(text):
    seq = tokenizer.texts_to_sequences([text])
    padded = pad_sequences(seq, maxlen=padded_inputs.shape[1], padding='post')
    pred = model.predict(padded)
    label_index = np.argmax(pred)
    response = lbl_encoder.inverse_transform([label_index])[0]
    return response


while True:
    user_input = input("You: ")
    if user_input.lower() in ['quit', 'exit', 'bye']:
        print("Chatbot: Goodbye!")
        break
    response = predict_reply(user_input)
    print("Chatbot:", response)

