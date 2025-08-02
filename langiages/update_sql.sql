-- Update da-DK
UPDATE public.i18n_translations
SET strings = $$
-- **********
-- JSON
-- **********
$$::jsonb
WHERE i18n_translations_id = '6d59211b-3273-4bdd-82ec-0c7f8f2c20e5';

-- Update en-US
UPDATE public.i18n_translations
SET strings = $$
-- **********
-- JSON
-- **********
$$::jsonb
WHERE i18n_translations_id = 'f32ce231-e5cc-4adc-a4e6-ded7217143cd';


-- Update sv-SE
UPDATE public.i18n_translations
SET strings = $$
-- **********
-- JSON
-- **********
$$::jsonb
WHERE i18n_translations_id = 'f47f35a4-5df4-4aa3-909a-d1d1eee03538';

-- Update fr-FR
UPDATE public.i18n_translations
SET strings = $$
-- **********
-- JSON
-- **********
$$::jsonb
WHERE i18n_translations_id = '85e3d720-8caa-4801-80c4-5616d25f9f92';

