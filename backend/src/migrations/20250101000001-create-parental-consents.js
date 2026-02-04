'use strict';

module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('parental_consents', {
      id: {
        type: Sequelize.UUID,
        defaultValue: Sequelize.UUIDV4,
        primaryKey: true,
      },
      user_id: {
        type: Sequelize.UUID,
        allowNull: false,
        references: {
          model: 'users',
          key: 'id',
        },
        onDelete: 'CASCADE',
        onUpdate: 'CASCADE',
      },
      parent_email: {
        type: Sequelize.STRING(255),
        allowNull: false,
      },
      consent_given: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      consent_date: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      consent_ip: {
        type: Sequelize.STRING(45),
        allowNull: true,
      },
      consent_token: {
        type: Sequelize.STRING(255),
        allowNull: true,
        unique: true,
      },
      consent_token_expires: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      revoked: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      revoked_date: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      revoked_reason: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      notification_sent: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      notification_sent_date: {
        type: Sequelize.DATE,
        allowNull: true,
      },
      created_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      updated_at: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });

    // Créer les index
    await queryInterface.addIndex('parental_consents', ['user_id'], {
      name: 'idx_parental_consents_user_id',
    });

    await queryInterface.addIndex('parental_consents', ['parent_email'], {
      name: 'idx_parental_consents_parent_email',
    });

    await queryInterface.addIndex('parental_consents', ['consent_token'], {
      name: 'idx_parental_consents_consent_token',
    });

    await queryInterface.addIndex('parental_consents', ['consent_given', 'revoked'], {
      name: 'idx_parental_consents_consent_status',
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('parental_consents');
  },
};
