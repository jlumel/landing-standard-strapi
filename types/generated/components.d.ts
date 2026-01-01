import type { Schema, Struct } from '@strapi/strapi';

export interface LayoutContact extends Struct.ComponentSchema {
  collectionName: 'components_layout_contacts';
  info: {
    description: '';
    displayName: 'Contacto';
    icon: 'phone';
  };
  attributes: {
    address: Schema.Attribute.Text;
    email: Schema.Attribute.Email;
    mapsLink: Schema.Attribute.Text;
    phone: Schema.Attribute.String;
  };
}

export interface LayoutHero extends Struct.ComponentSchema {
  collectionName: 'components_layout_heroes';
  info: {
    description: '';
    displayName: 'Hero';
    icon: 'landscape';
  };
  attributes: {
    bgImage: Schema.Attribute.Media<'images'>;
    companyName: Schema.Attribute.String;
    subtitle: Schema.Attribute.Text;
    title: Schema.Attribute.String;
  };
}

export interface LayoutInventory extends Struct.ComponentSchema {
  collectionName: 'components_layout_inventories';
  info: {
    description: '';
    displayName: 'Inventario';
    icon: 'car';
  };
  attributes: {
    cars: Schema.Attribute.Component<'layout.inventory-item', true>;
    subtitle: Schema.Attribute.String;
    title: Schema.Attribute.String;
  };
}

export interface LayoutInventoryItem extends Struct.ComponentSchema {
  collectionName: 'components_layout_inventory_items';
  info: {
    description: '';
    displayName: 'Auto';
    icon: 'check';
  };
  attributes: {
    brand: Schema.Attribute.String;
    image: Schema.Attribute.Media;
    mileage: Schema.Attribute.Integer;
    model: Schema.Attribute.String;
    year: Schema.Attribute.Integer;
  };
}

export interface SharedContactInfo extends Struct.ComponentSchema {
  collectionName: 'components_shared_contact_infos';
  info: {
    description: '';
    displayName: 'Informaci\u00F3n de contacto';
    icon: 'address-book';
  };
  attributes: {
    email: Schema.Attribute.Email;
    phone: Schema.Attribute.String;
    whatsappNumber: Schema.Attribute.String;
  };
}

export interface SharedScripts extends Struct.ComponentSchema {
  collectionName: 'components_shared_scripts';
  info: {
    description: '';
    displayName: 'Scripts';
    icon: 'code';
  };
  attributes: {
    extraHeadScripts: Schema.Attribute.JSON;
    googleAnalyticsId: Schema.Attribute.String;
    googleTagManagerId: Schema.Attribute.String;
  };
}

export interface SharedSeo extends Struct.ComponentSchema {
  collectionName: 'components_shared_seos';
  info: {
    description: '';
    displayName: 'SEO';
    icon: 'search';
  };
  attributes: {
    metaDescription: Schema.Attribute.Text;
    metaTitle: Schema.Attribute.String;
    ogImage: Schema.Attribute.Media<'images'>;
  };
}

declare module '@strapi/strapi' {
  export module Public {
    export interface ComponentSchemas {
      'layout.contact': LayoutContact;
      'layout.hero': LayoutHero;
      'layout.inventory': LayoutInventory;
      'layout.inventory-item': LayoutInventoryItem;
      'shared.contact-info': SharedContactInfo;
      'shared.scripts': SharedScripts;
      'shared.seo': SharedSeo;
    }
  }
}
