import type { Schema, Struct } from '@strapi/strapi';

export interface LayoutAbout extends Struct.ComponentSchema {
  collectionName: 'components_layout_abouts';
  info: {
    description: '';
    displayName: 'Acerca de';
    icon: 'information';
  };
  attributes: {
    content: Schema.Attribute.Blocks;
    image: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    title: Schema.Attribute.String;
  };
}

export interface LayoutContact extends Struct.ComponentSchema {
  collectionName: 'components_layout_contacts';
  info: {
    description: '';
    displayName: 'Contacto';
    icon: 'phone';
  };
  attributes: {
    subtitle: Schema.Attribute.Text;
    title: Schema.Attribute.String;
  };
}

export interface LayoutFeatureItem extends Struct.ComponentSchema {
  collectionName: 'components_layout_feature_items';
  info: {
    description: '';
    displayName: 'Caracter\u00EDstica';
    icon: 'check';
  };
  attributes: {
    description: Schema.Attribute.Text;
    icon: Schema.Attribute.String;
    title: Schema.Attribute.String;
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
    ctaLink: Schema.Attribute.String;
    ctaText: Schema.Attribute.String;
    image: Schema.Attribute.Media<'images' | 'files' | 'videos' | 'audios'>;
    subtitle: Schema.Attribute.Text;
    title: Schema.Attribute.String;
  };
}

export interface LayoutInventory extends Struct.ComponentSchema {
  collectionName: 'components_layout_features';
  info: {
    description: '';
    displayName: 'Caracter\u00EDsticas';
    icon: 'bulletList';
  };
  attributes: {
    items: Schema.Attribute.Component<'layout.feature-item', true>;
  };
}

export interface LayoutTestimonialItem extends Struct.ComponentSchema {
  collectionName: 'components_layout_testimonial_items';
  info: {
    description: '';
    displayName: 'Testimonio';
    icon: 'user';
  };
  attributes: {
    author: Schema.Attribute.String;
    quote: Schema.Attribute.Text;
    role: Schema.Attribute.String;
  };
}

export interface LayoutTestimonials extends Struct.ComponentSchema {
  collectionName: 'components_layout_testimonials';
  info: {
    description: '';
    displayName: 'Testimonios';
    icon: 'quote';
  };
  attributes: {
    items: Schema.Attribute.Component<'layout.testimonial-item', true>;
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
      'layout.about': LayoutAbout;
      'layout.contact': LayoutContact;
      'layout.feature-item': LayoutFeatureItem;
      'layout.hero': LayoutHero;
      'layout.inventory': LayoutInventory;
      'layout.testimonial-item': LayoutTestimonialItem;
      'layout.testimonials': LayoutTestimonials;
      'shared.contact-info': SharedContactInfo;
      'shared.scripts': SharedScripts;
      'shared.seo': SharedSeo;
    }
  }
}
