const mongoose = require("mongoose");

const messageSchema = new mongoose.Schema({
  role: {
    type: String,
    enum: ["user", "assistant"],
    required: true,
  },
  content: {
    type: String,
    required: true,
  },
  timestamp: {
    type: Date,
    default: Date.now,
  },
  mood_context: {
    type: Number,
    min: 1,
    max: 7,
    required: false,
  },
});

const conversationSchema = new mongoose.Schema(
  {
    user_id: {
      type: String,
      required: true,
      index: true,
    },
    messages: [messageSchema],
    created_at: {
      type: Date,
      default: Date.now,
    },
    updated_at: {
      type: Date,
      default: Date.now,
    },
  },
  {
    timestamps: { createdAt: "created_at", updatedAt: "updated_at" },
  }
);

// Index pour recherche rapide
conversationSchema.index({ user_id: 1, updated_at: -1 });

const Conversation = mongoose.model("Conversation", conversationSchema);

module.exports = Conversation;
