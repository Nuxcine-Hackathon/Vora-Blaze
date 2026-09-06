<?php

namespace Database\Seeders;

use App\Models\Modern\ItemCityFare;
use App\Models\Modern\ItemType;
use Illuminate\Database\Seeder;

class VehicleTypesTableSeeder extends Seeder
{
    /**
     * Seeds the two OnTravel ride categories (car and moto-taxi) for the Taxi
     * module (module=2), linked to the "Taxi" service type (id=1). The base
     * install ships with an empty rental_item_types table, so without this
     * the rider app's vehicle picker has nothing to show.
     */
    public function run()
    {
        $rows = [
            [
                'name' => 'Voiture',
                'description' => "Confort pour vos trajets, jusqu'à 4 passagers.",
                'min_fare' => 700,
                'max_fare' => 15000,
                'recommended_fare' => 1800,
            ],
            [
                'name' => 'Moto',
                'description' => 'Rapide et économique, idéal dans les embouteillages.',
                'min_fare' => 300,
                'max_fare' => 6000,
                'recommended_fare' => 700,
            ],
        ];

        foreach ($rows as $row) {
            if (ItemType::where('name', $row['name'])->exists()) {
                continue;
            }

            $itemType = ItemType::create([
                'name' => $row['name'],
                'description' => $row['description'],
                'status' => '1',
                'module' => 2,
                'max_weight' => null,
            ]);
            $itemType->serviceTypes()->sync([1]);

            ItemCityFare::create([
                'item_type_id' => $itemType->id,
                'min_fare' => $row['min_fare'],
                'max_fare' => $row['max_fare'],
                'recommended_fare' => $row['recommended_fare'],
                'admin_commission' => 15,
            ]);
        }
    }
}
