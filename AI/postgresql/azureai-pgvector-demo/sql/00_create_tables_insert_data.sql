-- 00_create_product_pgvector_table.sql
create database chat_on_your_data;

CREATE EXTENSION IF NOT EXISTS vector;

CREATE EXTENSION IF NOT EXISTS azure_ai;


/*
DROP TABLE IF EXISTS products_vector;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS reviews;
*/


-- Create products table
CREATE TABLE products (
    productid SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    category TEXT,
    description TEXT,
    image_data BYTEA
);





-- Create pgvector table for product embeddings
CREATE TABLE products_vector (
    productid INT NOT NULL,
    embedding VECTOR(1536),
    FOREIGN KEY (productid) REFERENCES products(productid)
);



-- verify tables are created
SELECT * FROM products;

SELECT * FROM products_vector;



-- Insert sample data into products table
INSERT INTO products (name, category, description) VALUES
('EchoBuds Pro', 'Audio', 'Wireless earbuds with noise cancellation'),
('PixelTab 11', 'Tablet', 'Android tablet with stylus support'),
('FlexCharge 65W', 'Charger', 'USB-C fast charger with dual ports'),
('SoundBar Mini', 'Audio', 'Compact soundbar with Bluetooth'),
('AirLite Keyboard', 'Accessories', 'Mechanical keyboard with RGB lighting'),
('VisionCam 4K', 'Webcam', '4K webcam with AI framing'),
('SmartWatch Pulse X', 'Wearables', 'Fitness watch with heart rate tracking'),
('ZenBook Air 14', 'Laptop', 'Ultrabook with OLED display'),
('GamePad Neo', 'Gaming', 'Wireless controller with haptics'),
('HomeHub Max', 'Smart Home', 'Smart display with assistant'),
('EchoBuds Lite', 'Audio', 'Budget wireless earbuds'),
('PixelTab Mini', 'Tablet', 'Compact tablet for kids'),
('FlexCharge 100W', 'Charger', 'High-power USB-C charger'),
('SoundBar Ultra', 'Audio', 'Premium soundbar with Dolby Atmos'),
('AirLite Pro', 'Accessories', 'Wireless mechanical keyboard'),
('VisionCam HD', 'Webcam', 'HD webcam with privacy shutter'),
('SmartWatch Fit', 'Wearables', 'Slim fitness tracker'),
('ZenBook Pro', 'Laptop', 'High-performance laptop'),
('GamePad Lite', 'Gaming', 'Compact controller for mobile'),
('HomeHub Mini', 'Smart Home', 'Small smart display'),
('EchoBuds Sport', 'Audio', 'Earbuds for workouts'),
('PixelTab Edu', 'Tablet', 'Tablet for education'),
('FlexCharge Travel', 'Charger', 'Travel-friendly charger'),
('SoundBar Go', 'Audio', 'Portable soundbar'),
('AirLite Compact', 'Accessories', 'Compact keyboard'),
('VisionCam Stream', 'Webcam', 'Streaming webcam'),
('SmartWatch Luxe', 'Wearables', 'Luxury smartwatch'),
('ZenBook Studio', 'Laptop', 'Laptop for creators'),
('GamePad Pro', 'Gaming', 'Pro-grade controller'),
('HomeHub Voice', 'Smart Home', 'Voice-only smart assistant'),
('EchoBuds ANC', 'Audio', 'Earbuds with adaptive noise canceling'),
('PixelTab Studio', 'Tablet', 'Tablet for digital artists'),
('FlexCharge Car', 'Charger', 'Car charger with USB-C'),
('SoundBar Bass', 'Audio', 'Soundbar with enhanced bass'),
('AirLite Travel', 'Accessories', 'Foldable keyboard for travel'),
('VisionCam Pro', 'Webcam', 'Professional webcam'),
('EcoTherm Smart Heater', 'Smart Home', 'Energy-efficient smart heater with app control and scheduling'),
('HydroPure Bottle', 'Lifestyle', 'Self-cleaning water bottle with UV sterilization and hydration tracking'),
('SkyView Telescope', 'Outdoor', 'Portable digital telescope with smartphone connectivity'),
('ChefBot Mini', 'Kitchen', 'Compact cooking assistant robot with recipe integration'),
('GlowSkin Mirror', 'Health & Beauty', 'Smart mirror with skin analysis and personalized care tips'),
('TrackMate Luggage', 'Travel', 'Smart luggage with GPS tracking and weight sensors'),
('BioFit Chair', 'Furniture', 'Ergonomic chair with posture correction and pressure sensors'),
('SolarBright Lantern', 'Outdoor', 'Solar-powered lantern with USB charging and adjustable brightness'),
('PetCare Feeder', 'Pet Tech', 'Automatic pet feeder with camera and app scheduling'),
('AirSense Purifier', 'Home Appliances', 'Smart air purifier with real-time air quality monitoring');



-- verify data insertion
-- notice no data for image_data column yet but you can add it later if you want
SELECT * FROM products LIMIT 5;



-- Create reviews table
CREATE TABLE product_reviews (
    reviewid SERIAL PRIMARY KEY,
    productid INT NOT NULL,
    review_text TEXT NOT NULL,
    FOREIGN KEY (productid) REFERENCES products(productid)
);


-- verify table creation
SELECT * FROM product_reviews;


INSERT INTO product_reviews (productid, review_text) VALUES
-- EchoBuds Pro (productid = 1)
(1, 'Amazing sound quality and noise cancellation!'),
(1, 'Battery life could be better.'),
(1, 'Comfortable fit but a bit pricey.'),
(1, 'Great for calls and music.'),
(1, 'Occasional connectivity issues. From reviewer John D., phone number is 123-456-7890, address is 123 Main Street, Springfield, USA.'),
-- PixelTab 11 (productid = 2)
(2, 'Excellent display and fast performance. From reviewer Alice M., phone number is 987-654-3210, address is 456 Oak Avenue, Metropolis, USA.'),
(2, 'Stylus support is great for note-taking.'),
(2, 'Battery drains quickly when gaming.'),
(2, 'Good for everyday tasks.'),
(2, 'Price is reasonable for the features.'),
-- FlexCharge 65W (productid = 3)
(3, 'Charges devices super fast!'),
(3, 'Gets warm during long use.'),
(3, 'Compact design fits easily in bags.'),
(3, 'Cable quality could be better.'),
(3, 'Reliable for travel and home use.'),
-- SoundBar Mini (productid = 4)
(4, 'Clear sound and good bass for its size.'),
(4, 'Bluetooth pairing sometimes fails.'),
(4, 'Perfect for small rooms.'),
(4, 'Volume could be louder.'),
(4, 'Affordable and stylish design.'),
-- AirLite Keyboard (productid = 5)
(5, 'Keys feel smooth and responsive.'),
(5, 'No backlight option is disappointing.'),
(5, 'Lightweight and easy to carry.'),
(5, 'Occasional lag in wireless mode.'),
(5, 'Great for typing and gaming.'),
-- VisionCam 4K (productid = 6)
(6, 'Crystal-clear video quality and sharp details.'),
(6, 'Low-light performance could be improved.'),
(6, 'Easy setup and user-friendly interface.'),
(6, 'Occasional lag during streaming.'),
(6, 'Great value for the price.'),
-- SmartWatch Pulse X (productid = 7)
(7, 'Accurate heart rate tracking and fitness features.'),
(7, 'Battery life is shorter than expected.'),
(7, 'Stylish design and comfortable to wear.'),
(7, 'Notifications sometimes delay.'),
(7, 'Excellent for workouts and daily use.'),
-- ZenBook Air 14 (productid = 8)
(8, 'Lightweight and perfect for travel.'),
(8, 'Performance is solid for everyday tasks. From reviewer Robert K., phone number is 555-123-4567, address is 789 Pine Street, Gotham City, USA.'),
(8, 'Screen brightness could be better outdoors.'),
(8, 'Keyboard feels great for typing.'),
(8, 'Price is a bit high compared to competitors.'),
-- GamePad Neo (productid = 9)
(9, 'Responsive controls and smooth gameplay.'),
(9, 'Build quality feels a little cheap.'),
(9, 'Comfortable grip for long sessions.'),
(9, 'Occasional connectivity drops.'),
(9, 'Great for casual and competitive gaming. From reviewer Maria L., phone number is 222-333-4444, address is 321 Maple Road, Star City, USA.'),
-- HomeHub Max (productid = 10)
(10, 'Excellent smart home integration.'),
(10, 'Voice recognition works well most of the time.'),
(10, 'Occasionally slow to respond to commands.'),
(10, 'Sleek design and fits any room.'),
(10, 'Setup process was quick and easy.'),
-- EchoBuds Lite (productid = 11)
(11, 'Decent sound quality for the price.'),
(11, 'Battery lasts long enough for daily use.'),
(11, 'Noise cancellation is not as strong as Pro version.'),
(11, 'Comfortable fit for extended wear.'),
(11, 'Occasional pairing issues with Bluetooth.'),
-- PixelTab Mini (productid = 12)
(12, 'Compact size makes it easy to carry.'),
(12, 'Performance is good for basic tasks.'),
(12, 'Screen resolution could be better.'),
(12, 'Affordable and practical for students.'),
(12, 'Limited storage space is a drawback.'),
-- FlexCharge 100W (productid = 13)
(13, 'Charges laptops and phones super fast.'),
(13, 'Bulky design compared to 65W version.'),
(13, 'Reliable for heavy-duty charging needs.'),
(13, 'Gets warm during extended use.'),
(13, 'Excellent build quality and durability.'),
-- SoundBar Ultra (productid = 14)
(14, 'Outstanding sound clarity and Dolby Atmos support.'),
(14, 'Bass is deep and immersive.'),
(14, 'Setup was easy and quick. From reviewer David P., phone number is 111-222-3333, address is 654 Elm Boulevard, Central City, USA.'),
(14, 'Price is on the higher side.'),
(14, 'Perfect for home theater experience.'),
-- AirLite Pro (productid = 15)
(15, 'Premium feel and responsive keys.'),
(15, 'Wireless connectivity is stable.'),
(15, 'No RGB lighting option.'),
(15, 'Lightweight and ergonomic design.'),
(15, 'Great for professional use.'),
-- VisionCam HD (productid = 16)
(16, 'Good video quality for everyday use.'),
(16, 'Struggles in low-light conditions.'),
(16, 'Easy to install and configure.'),
(16, 'Audio capture could be clearer.'),
(16, 'Affordable and reliable for home security.'),
-- SmartWatch Fit (productid = 17)
(17, 'Great fitness tracking features.'),
(17, 'Battery lasts for several days.'),
(17, 'Screen is hard to read in bright sunlight.'),
(17, 'Comfortable strap for workouts.'),
(17, 'Limited app compatibility compared to competitors.'),
-- ZenBook Pro (productid = 18)
(18, 'Powerful performance for creative tasks.'),
(18, 'Premium build quality and sleek design.'),
(18, 'Gets warm under heavy load.'),
(18, 'Excellent display for photo editing.'),
(18, 'Price is high but justified for specs.'),
-- GamePad Lite (productid = 19)
(19, 'Lightweight and easy to carry.'),
(19, 'Buttons feel less durable than expected.'),
(19, 'Good for casual gaming sessions.'),
(19, 'Connectivity is stable most of the time.'),
(19, 'Affordable option for budget gamers.'),
-- HomeHub Mini (productid = 20)
(20, 'Compact design fits anywhere.'),
(20, 'Voice assistant works well for basic commands.'),
(20, 'Limited speaker quality for music.'),
(20, 'Setup process was simple and quick.'),
(20, 'Great for controlling smart devices.'),
-- EchoBuds Sport (productid = 21)
(21, 'Perfect for workouts with secure fit.'),
(21, 'Sweat resistance works well during runs.'),
(21, 'Sound quality is decent but not exceptional.'),
(21, 'Battery life could be longer for outdoor activities. From reviewer Sophia R., phone number is 444-555-6666, address is 987 Cedar Lane, Coast City, USA.'),
(21, 'Affordable option for fitness enthusiasts.'),
-- PixelTab Edu (productid = 22)
(22, 'Great for online classes and educational apps.'),
(22, 'Lightweight and easy for kids to handle.'),
(22, 'Performance slows down with multiple apps open.'),
(22, 'Durable build for school use.'),
(22, 'Limited gaming capability but good for learning.'),
-- FlexCharge Travel (productid = 23)
(23, 'Compact and convenient for trips.'),
(23, 'Charges multiple devices at once.'),
(23, 'Cable length is shorter than expected.'),
(23, 'Reliable for quick charging on the go.'),
(23, 'Build quality feels solid and durable.'),
-- SoundBar Go (productid = 24)
(24, 'Portable and easy to carry anywhere.'),
(24, 'Sound quality is good for its size.'),
(24, 'Battery life is average for outdoor use.'),
(24, 'Bluetooth connection is stable most of the time.'),
(24, 'Perfect for small gatherings and travel.'),
-- AirLite Compact (productid = 25)
(25, 'Compact design saves desk space.'),
(25, 'Keys feel responsive and smooth.'),
(25, 'No backlight option for night use.'),
(25, 'Wireless mode works without lag.'),
(25, 'Affordable and practical for everyday typing.'),
-- VisionCam Stream (productid = 26)
(26, 'Great for live streaming with clear video quality.'),
(26, 'Audio sync issues occur occasionally.'),
(26, 'Easy to connect and configure with apps.'),
(26, 'Low-light performance could be better.'),
(26, 'Affordable option for content creators.'),
-- SmartWatch Luxe (productid = 27)
(27, 'Premium design and stylish look.'),
(27, 'Battery life is shorter than expected.'),
(27, 'Excellent health tracking features.'),
(27, 'Screen brightness is impressive.'),
(27, 'Price feels high compared to similar models.'),
-- ZenBook Studio (productid = 28)
(28, 'Powerful specs for creative professionals.'),
(28, 'Display quality is top-notch for editing.'),
(28, 'Gets warm during heavy workloads.'),
(28, 'Keyboard feels comfortable for long typing sessions.'),
(28, 'Expensive but worth it for performance.'),
-- GamePad Pro (productid = 29)
(29, 'Responsive controls and smooth gameplay experience.'),
(29, 'Build quality feels solid and durable.'),
(29, 'Connectivity is stable even during long sessions.'),
(29, 'Buttons could be more ergonomic.'),
(29, 'Great for competitive gaming.'),
-- HomeHub Voice (productid = 30)
(30, 'Voice commands work flawlessly most of the time.'),
(30, 'Integration with smart devices is seamless.'),
(30, 'Occasional delays in response.'),
(30, 'Compact design fits well in any room.'),
(30, 'Setup process was quick and easy.'),
-- EchoBuds ANC (productid = 31)
(31, 'Active noise cancellation works really well.'),
(31, 'Sound quality is impressive for the price.'),
(31, 'Battery drains faster with ANC on.'),
(31, 'Comfortable fit for long listening sessions.'),
(31, 'Occasional Bluetooth pairing issues.'),
-- PixelTab Studio (productid = 32)
(32, 'Perfect for creative professionals and designers.'),
(32, 'High-resolution display is stunning.'),
(32, 'Performance slows down with heavy apps.'),
(32, 'Stylus response is excellent for drawing.'),
(32, 'Price is quite high compared to alternatives.'),
-- FlexCharge Car (productid = 33)
(33, 'Charges devices quickly while driving.'),
(33, 'Compact design fits perfectly in the car socket.'),
(33, 'Gets warm during long trips.'),
(33, 'Reliable for multiple devices at once.'),
(33, 'Cable length could be longer for convenience.'),
-- SoundBar Bass (productid = 34)
(34, 'Deep bass and clear sound quality.'),
(34, 'Perfect for music lovers.'),
(34, 'Bluetooth connection sometimes drops.'),
(34, 'Stylish design and easy setup.'),
(34, 'Volume could be louder for large rooms.'),
-- AirLite Travel (productid = 35)
(35, 'Lightweight and easy to pack for trips.'),
(35, 'Keys feel smooth and responsive.'),
(35, 'No backlight option for night use.'),
(35, 'Wireless mode works without lag.'),
(35, 'Affordable and practical for travelers.'),
-- VisionCam Pro (productid = 36)
(36, 'Exceptional video clarity and professional-grade features.'),
(36, 'Setup takes longer than expected.'),
(36, 'Great for security and live streaming.'),
(36, 'Price is high but justified for quality.'),
(36, 'Low-light performance is impressive.'),
-- EcoTherm Smart Heater (productid = 37)
(37, 'Heats up rooms quickly and efficiently.'),
(37, 'Smart controls make it easy to manage remotely.'),
(37, 'Consumes more power than expected.'),
(37, 'Compact design fits well in small spaces.'),
(37, 'Occasional connectivity issues with the app.'),
-- HydroPure Bottle (productid = 38)
(38, 'Keeps water fresh and clean all day.'),
(38, 'Built-in filter works great for outdoor use.'),
(38, 'Cap feels a little flimsy.'),
(38, 'Lightweight and easy to carry.'),
(38, 'Perfect for hiking and travel.'),
-- SkyView Telescope (productid = 39)
(39, 'Amazing clarity for stargazing.'),
(39, 'Setup instructions could be clearer.'),
(39, 'Portable and easy to transport.'),
(39, 'Lens quality is excellent for beginners.'),
(39, 'Price is reasonable for the features offered.'),
-- ChefBot Mini (productid = 40)
(40, 'Makes cooking easier with automated features.'),
(40, 'Compact size is perfect for small kitchens.'),
(40, 'Occasionally struggles with complex recipes.'),
(40, 'Easy to clean and maintain.'),
(40, 'Great time-saver for busy households.'),
-- GlowSkin Mirror (productid = 41)
(41, 'Lighting is perfect for makeup and skincare routines.'),
(41, 'Smart features are useful but sometimes laggy.'),
(41, 'Mirror quality is excellent and clear.'),
(41, 'Price feels a bit high for the features offered.'),
(41, 'Easy to adjust brightness and color temperature.'),
-- TrackMate Luggage (productid = 42)
(42, 'Built-in tracker is a lifesaver for frequent travelers.'),
(42, 'Durable material and smooth wheels.'),
(42, 'App connectivity sometimes fails.'),
(42, 'Spacious compartments for organized packing.'),
(42, 'Lightweight and stylish design.'),
-- BioFit Chair (productid = 43)
(43, 'Extremely comfortable for long working hours.'),
(43, 'Ergonomic design supports posture well.'),
(43, 'Assembly instructions could be clearer.'),
(43, 'Premium build quality and sturdy frame.'),
(43, 'Price is high but worth the comfort.'),
-- SolarBright Lantern (productid = 44)
(44, 'Charges quickly under sunlight and lasts all night.'),
(44, 'Perfect for camping and outdoor activities.'),
(44, 'Light output could be brighter.'),
(44, 'Compact and easy to carry.'),
(44, 'Occasional issues with charging on cloudy days.'),
-- PetCare Feeder (productid = 45)
(45, 'Makes feeding pets so much easier.'),
(45, 'App notifications are helpful but sometimes delayed.'),
(45, 'Build quality feels solid and safe for pets.'),
(45, 'Setup process was simple and quick.'),
(45, 'Occasional connectivity issues with Wi-Fi.'),
-- AirSense Purifier (productid = 46)
(46, 'Air feels fresher within minutes of use.'),
(46, 'Quiet operation even at high settings.'),
(46, 'Filter replacement cost is a bit high.'),
(46, 'Compact design fits well in small rooms.'),
(46, 'Smart sensors work accurately most of the time.');


-- verify table creation
SELECT * FROM product_reviews LIMIT 5;




-- Create product review summary table
-- this table will hold the abstractive summaries and sentiment analysis results
CREATE TABLE product_review_summary (
    productid INT NOT NULL,
    abstractive_summary TEXT,           -- Holds the summarized review text
    sentiment_label TEXT,               -- Overall sentiment (positive, neutral, negative)
    positive_score DOUBLE PRECISION,    -- Sentiment confidence for positive
    neutral_score DOUBLE PRECISION,     -- Sentiment confidence for neutral
    negative_score DOUBLE PRECISION,    -- Sentiment confidence for negative
    created_at TIMESTAMP DEFAULT NOW()  -- Timestamp for when the summary was generated
);


